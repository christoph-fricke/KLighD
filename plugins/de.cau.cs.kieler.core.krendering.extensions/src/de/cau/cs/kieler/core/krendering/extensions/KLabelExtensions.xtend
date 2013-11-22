/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2012 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.core.krendering.extensions

import javax.inject.Inject
import de.cau.cs.kieler.core.kgraph.KLabel
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.kiml.klayoutdata.KShapeLayout
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.core.krendering.KRendering
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.kiml.options.NodeLabelPlacement
import de.cau.cs.kieler.kiml.options.PortLabelPlacement
import java.util.List
import de.cau.cs.kieler.core.kgraph.KPort

/**
 * @author chsch
 * 
 * @containsExtensions
 */
@ViewSynthesisShared
class KLabelExtensions {
    
    static KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE
    
    @Inject
    extension KNodeExtensions

    @Inject
    extension KRenderingExtensions
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////                    KLabelExtensions
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * A convenient getter preserving the element image relation by a create extension.
     */ 
    def private KLabel create node: KimlUtil::createInitializedLabel(labeledElement) getLabel(List<?> o,
            KLabeledGraphElement labeledElement) {
    }
    
    /**
     * A convenient getter preserving the element image relation by a create extension.
     */
    def KLabel getLabel(Object o, KLabeledGraphElement labeledElement) {
        return newArrayList(o).getLabel(labeledElement)
    }
    
    /**
     * Convenience creator of KLabels that are not related to semantic elements.
     * It is just syntactic sugar.  
     */
    def KLabel createLabel(KLabeledGraphElement labeledElement) {
        return KimlUtil::createInitializedLabel(labeledElement)
    }
    
    /**
     * An alias of {@link #getLabel(Object, KLabeledGraphElement)} allowing to express in business
     *  that the KLabel will be created at this place. It is just syntactic sugar.  
     */
    def KLabel createLabel(Object o, KLabeledGraphElement labeledElement) {
        return newArrayList(o).getLabel(labeledElement)
    }
    
    /**
     * A convenient getter associating the label with to elements
     *  preserving the element image relation by a create extension.
     */
    def KLabel getLabel(Object o1, Object o2, KLabeledGraphElement labeledElement) {
        return newArrayList(o1, o2).getLabel(labeledElement)
    }
    
    /**
     * An alias of {@link #getLabel(Object, Object, KLabeledGraphElement)} allowing to express in business
     *  that the KLabel will be created at this place. It is just syntactic sugar.  
     */
    def KLabel createLabel(Object o1, Object o2, KLabeledGraphElement labeledElement) {
        return newArrayList(o1, o2).getLabel(labeledElement)
    }
    
    
    def KLabel setLabelSize(KLabel label, float width, float height) {
        return label => [
            getData(typeof(KShapeLayout)).setSize(width, height)
        ];
    }
    
    def KLabel setLabelPos(KLabel label, float x, float y) {
        return label => [
            getData(typeof(KShapeLayout)).setPos(x, y)
        ];
    }
    
    def KLabel addLayoutParam(KLabel node, IProperty<?> property, Object value) {
        return node => [
            it.getData(typeof(KShapeLayout)).setProperty(property, value)
        ];
    }


    /* --------------------------------- */
    /*  node label configurators/adders  */
    /* --------------------------------- */
    
    /**
     * Configures a central node label!
     */
    def KLabel configureOutsideCentralBottomNodeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            val node = it.parent;
            switch(node) {
                KNode: node.addLayoutParam(LayoutOptions::NODE_LABEL_PLACEMENT, NodeLabelPlacement::outsideBottomCenter)
            }
        ];
    }

    /**
     * Adds a central node label to KNode 'node'!
     */
    def KLabel addOutsideCentralBottomNodeLabel(KNode node, String labelText, int fontSize, String fontName) {
        return node.createLabel().configureOutsideCentralBottomNodeLabel(labelText, fontSize, fontName);
    }
    
    /**
     * Configures a left-aligned node label!
     */
    def KLabel configureOutsideBottomLeftNodeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            val node = it.parent;
            switch(node) {
                KNode: node.addLayoutParam(LayoutOptions::NODE_LABEL_PLACEMENT, NodeLabelPlacement::outsideBottomLeft)
            }
        ];
    }
    
     /**
     * Adds a left-aligned node label to KNode 'node'!
     */
    def KLabel addOutsideBottomLeftNodeLabel(KNode node, String labelText, int fontSize, String fontName) {
        return node.createLabel().configureOutsideBottomLeftNodeLabel(labelText, fontSize, fontName);
    }

    /**
     * Configures a central node label!
     */
    def KLabel configureOutsideBottomRightNodeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            val node = it.parent;
            switch(node) {
                KNode: node.addLayoutParam(LayoutOptions::NODE_LABEL_PLACEMENT, NodeLabelPlacement::outsideBottomRight)
            }
        ];
    }
    
    /**
     * Adds a central node label to KNode 'node'!
     */
    def KLabel addOutsideBottomRightNodeLabel(KNode node, String labelText, int fontSize, String fontName) {
        return node.createLabel().configureOutsideBottomRightNodeLabel(labelText, fontSize, fontName);
    }


    /* --------------------------------- */
    /*  port label configurators/adders  */
    /* --------------------------------- */

    /**
     * Configures an inside port label!<br>
     * Note that <code>label</code> must be already contained in a {@link KPort} that in turn is contained
     * in a {@link KNode} in order to let the configuration be performed properly.
     */
    def KLabel configureInsidePortLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            val node = it.parent?.eContainer;
            switch(node) {
                KNode: node.addLayoutParam(LayoutOptions::PORT_LABEL_PLACEMENT, PortLabelPlacement::INSIDE)
            }
        ];
    }

    /**
     * Adds an inside label to {@link KPort} <code>port</code>!<br>
     * Note that <code>port</code> must be already contained in a {@link KNode} in order to let the
     * configuration be performed properly.
     */
    def KLabel addInsidePortLabel(KPort port, String labelText, int fontSize, String fontName) {
        return port.createLabel().configureInsidePortLabel(labelText, fontSize, fontName);
    }

    /**
     * Configures a outside port label!<br>
     * Note that <code>label</code> must be already contained in a {@link KPort} that in turn is contained
     * in a {@link KNode} in order to let the configuration be performed properly.
     */
    def KLabel configureOutsidePortLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            val node = it.parent?.eContainer;
            switch(node) {
                KNode: node.addLayoutParam(LayoutOptions::PORT_LABEL_PLACEMENT, PortLabelPlacement::OUTSIDE)
            }
        ];
    }

    /**
     * Adds an outside label to {@link KPort} <code>port</code>!<br>
     * Note that <code>port</code> must be already contained in a {@link KNode} in order to let the
     * configuration be performed properly.
     */
    def KLabel addOutsidePortLabel(KPort port, String labelText, int fontSize, String fontName) {
        return port.createLabel().configureOutsidePortLabel(labelText, fontSize, fontName);
    }


    /* --------------------------------- */
    /*  edge label configurators/adders  */
    /* --------------------------------- */

    /**
     * Configures a central (main) edge label, e.g. a state transition guard/effect label!
     * 
     * @deprecated Use {@link #configureCenteralEdgeLabel(KLabel, String, int, String)} instead!
     */
    def KLabel configureCenteralLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return configureCenteralEdgeLabel(label, labelText, fontSize, fontName);
    }
    
    /**
     * Configures a central (main) edge label, e.g. a state transition guard/effect label!
     */
    def KLabel configureCenteralEdgeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER);
        ];
    }
    
    /**
     * Configures a head edge label, e.g. the cardinality of a relation in an class diagram!
     * 
     * @deprecated Use {@link #configureHeadEdgeLabel(KLabel, String, int, String)} instead!
     */
    def KLabel configureHeadLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return configureHeadEdgeLabel(label, labelText, fontSize, fontName);
    }

    /**
     * Configures a head edge label, e.g. the cardinality of a relation in an class diagram!
     */
    def KLabel configureHeadEdgeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::HEAD);
        ];
    }
    
    /**
     * Configures a tail edge label, e.g. the cardinality of a relation in an class diagram!
     * 
     * @deprecated Use {@link #configureTailEdgeLabel(KLabel, String, int, String)} instead!
     */
    def KLabel configureTailLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return configureTailEdgeLabel(label, labelText, fontSize, fontName);
    }

    /**
     * Configures a tail edge label, e.g. the cardinality of a relation in an class diagram!
     */
    def KLabel configureTailEdgeLabel(KLabel label, String labelText, int fontSize, String fontName) {
        return label => [
            it.basicConfigureLabel(labelText, fontSize, fontName);
            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::TAIL);
        ];
    }
    

    /* ----------------- */
    /*   other helpers   */
    /* ----------------- */

    /**
     * The least common denominator of all the 'configure...Label' methods.<br>
     * Is private as it's to be used internally only!
     */
    def private void basicConfigureLabel(KLabel label, String labelText, int fontSize, String fontName) {
        label.text = labelText;
        label.data += renderingFactory.createKText().setFontName(fontName).setFontSize(fontSize);
        label.addLayoutParam(LayoutOptions::FONT_NAME, fontName);
        label.addLayoutParam(LayoutOptions::FONT_SIZE, fontSize);
    }
    
    /**
     * Reveals the first KText element of a label KRendering, which is assumed to be the label text configuration.
     * This is useful for additionally linking it with the business element represented by the label.
     * 
     * Note: KLabelNodes of the Piccolo2D binding are configured to ignore the KText element while selecting them.
     * Thus, only the KLabel needs to be linked to the source element. 
     */
    def KText getFirstText(KLabel label) {
        return label?.getData(typeof(KText))?:(label?.getData(typeof(KRendering))?.eAllContents?.filter(typeof(KText))?.head);
    }

    
}